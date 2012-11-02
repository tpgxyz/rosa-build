# -*- encoding : utf-8 -*-
#require 'lib/build_server.rb'
class Platform < ActiveRecord::Base
  VISIBILITIES = ['open', 'hidden']

  belongs_to :parent, :class_name => 'Platform', :foreign_key => 'parent_platform_id'
  belongs_to :owner, :polymorphic => true

  has_many :repositories, :dependent => :destroy
  has_many :products, :dependent => :destroy

  has_many :relations, :as => :target, :dependent => :destroy
  has_many :actors, :as => :target, :class_name => 'Relation', :dependent => :destroy
  has_many :members, :through => :actors, :source => :actor, :source_type => 'User'

  has_and_belongs_to_many :advisories

  has_many :packages, :class_name => "BuildList::Package", :dependent => :destroy

  has_many :mass_builds

  validates :description, :presence => true
  validates :owner, :presence => true
  validates :visibility, :presence => true, :inclusion => {:in => VISIBILITIES}
  validates :name, :uniqueness => {:case_sensitive => false}, :presence => true, :format => { :with => /^[a-zA-Z0-9_\-\.]+$/ }
  validates :distrib_type, :presence => true, :inclusion => {:in => APP_CONFIG['distr_types']}
  validate lambda {
    if released_was && !released
      errors.add(:released, I18n.t('flash.platform.released_status_can_not_be_changed'))
    end
  }

  before_create :create_directory, :if => lambda {Thread.current[:skip]} # TODO remove this when core will be ready
  before_create :xml_rpc_create, :unless => lambda {Thread.current[:skip]}
  before_destroy :xml_rpc_destroy

  after_update :freeze_platform_and_update_repos
  after_update :update_owner_relation

  after_create lambda { symlink_directory unless hidden? }
  after_destroy lambda { remove_symlink_directory unless hidden? }

  scope :search_order, order("CHAR_LENGTH(name) ASC")
  scope :search, lambda {|q| where("name ILIKE ?", "%#{q.to_s.strip}%")}
  scope :by_visibilities, lambda {|v| where(:visibility => v)}
  scope :opened, where(:visibility => 'open')
  scope :hidden, where(:visibility => 'hidden')
  scope :by_type, lambda {|type| where(:platform_type => type) if type.present?}
  scope :main, by_type('main')
  scope :personal, by_type('personal')

  attr_accessible :name, :distrib_type, :parent_platform_id, :platform_type, :owner, :visibility, :description, :released
  attr_readonly   :name, :distrib_type, :parent_platform_id, :platform_type

  include Modules::Models::Owner

  def clear
    system("rm -Rf #{ APP_CONFIG['root_path'] }/platforms/#{ self.name }/repository/*")
  end

  def urpmi_list(host, pair = nil)
    blank_pair = {:login => 'login', :pass => 'password'}
    pair = blank_pair if pair.blank?
    urpmi_commands = ActiveSupport::OrderedHash.new

    Platform.main.opened.where(:distrib_type => APP_CONFIG['distr_types'].first).each do |pl|
      urpmi_commands[pl.name] = {}
      local_pair = pl.id != self.id ? blank_pair : pair
      head = hidden? ? "http://#{local_pair[:login]}@#{local_pair[:pass]}:#{host}/private/" : "http://#{host}/downloads/"
      Arch.all.each do |arch|
        tail = "/#{arch.name}/main/release"
        urpmi_commands[pl.name][arch.name] = "urpmi.addmedia #{name} #{head}#{name}/repository/#{pl.name}#{tail}"
      end
    end

    return urpmi_commands
  end

  def path
    build_path(name)
  end

  def add_member(member, role = 'admin')
    Relation.add_member(member, self, role)
  end

  def remove_member(member)
    Relation.remove_member(member, self)
  end

  def symlink_path
    Rails.root.join("public", "downloads", name)
  end

  def prefix_url(pub, options = {})
    options[:host] ||= EventLog.current_controller.request.host_with_port rescue ::Rosa::Application.config.action_mailer.default_url_options[:host]
    pub ? "http://#{options[:host]}/downloads" : "http://#{options[:login]}:#{options[:password]}@#{options[:host]}/private"
  end

  def public_downloads_url(host = nil, arch = nil, repo = nil, suffix = nil)
    downloads_url prefix_url(true, :host => host), arch, repo, suffix
  end

  def private_downloads_url(login, password, host = nil, arch = nil, repo = nil, suffix = nil)
    downloads_url prefix_url(false, :host => host, :login => login, :password => password), arch, repo, suffix
  end

  def downloads_url(prefix, arch = nil, repo = nil, suffix = nil)
    "#{prefix}/#{name}/repository/".tap do |url|
      url << "#{arch}/" if arch.present?
      url << "#{repo}/" if repo.present?
      url << "#{suffix}/" if suffix.present?
    end
  end

  def hidden?
    visibility == 'hidden'
  end

  def personal?
    platform_type == 'personal'
  end

  def main?
    platform_type == 'main'
  end

  def base_clone(attrs = {}) # :description, :name, :owner
    dup.tap do |c|
      attrs.each {|k,v| c.send("#{k}=", v)} # c.attributes = attrs
      c.updated_at = nil; c.created_at = nil
      c.parent = self; c.released = false
    end
  end

  def clone_relations(from = parent)
    self.repositories = from.repositories.map{|r| r.full_clone(:platform_id => id)}
    self.products = from.products.map(&:full_clone)
  end

  def full_clone(attrs = {})
    base_clone(attrs).tap do |c|
      with_skip {c.save} and c.clone_relations(self) and c.xml_rpc_clone # later with resque
    end
  end

  def change_visibility
    if !hidden?
      update_attributes(:visibility => 'hidden')
      remove_symlink_directory
    else
      update_attributes(:visibility => 'open')
      symlink_directory
    end
  end

  def create_directory
    system("sudo mkdir -p -m 0777 #{path}")
  end

  def symlink_directory
    # umount_directory_for_rsync # TODO ignore errors
    system("ln -s #{path} #{symlink_path}")
    Arch.all.each do |arch|
      str = "country=Russian Federation,city=Moscow,latitude=52.18,longitude=48.88,bw=1GB,version=2011,arch=#{arch.name},type=distrib,url=#{public_downloads_url}\n"
      File.open(File.join(symlink_path, "#{name}.#{arch.name}.list"), 'w') {|f| f.write(str) }
    end
  end

  def remove_symlink_directory
    system("rm -Rf #{symlink_path}")
  end

  def update_owner_relation
    if owner_id_was != owner_id
      r = relations.where(:actor_id => owner_id_was, :actor_type => owner_type_was).first
      r.update_attributes(:actor_id => owner_id, :actor_type => owner_type)
    end
  end

  def build_all(opts={})
    # Set options to build all need
    repositories = opts[:repositories] ? self.repositories.where(:id => opts[:repositories]) : self.repositories
    arches = opts[:arches] ? Arch.where(:id => opts[:arches]) : Arch.all
    auto_publish = opts[:auto_publish] || false
    user = opts[:user]
    mass_build_id = opts[:mass_build_id]
    mass_build = MassBuild.find mass_build_id

    repositories.each do |rep|
      rep.projects.find_in_batches(:batch_size => 2) do |group|
        sleep 1
        group.each do |p|
          arches.map(&:name).each do |arch|
            begin
              return if mass_build.reload.stop_build
              p.build_for(self, rep.id, user, arch, auto_publish, mass_build_id)
            rescue RuntimeError, Exception
              # p.async(:build_for, self, user, arch, auto_publish, mass_build_id) # TODO need this?
            end
          end
        end
      end
    end
  end
  later :build_all, :loner => true, :queue => :clone_build

  def destroy
    with_skip {super} # avoid cascade XML RPC requests
  end
  later :destroy, :queue => :clone_build

  protected

    def build_path(dir)
      File.join(APP_CONFIG['root_path'], 'platforms', dir)
    end

    def xml_rpc_create
      result = BuildServer.add_platform name, APP_CONFIG['root_path'] + '/platforms' , distrib_type
      if result == BuildServer::SUCCESS
        return true
      else
        raise "Failed to create platform #{name} with code #{result}. Path: #{build_path(name)}"
      end
    end

    def xml_rpc_destroy
      result = BuildServer.delete_platform name
      if result == BuildServer::SUCCESS
        return true
      else
        raise "Failed to delete platform #{name} with code #{result}."
      end
    end

    def xml_rpc_clone(old_name = parent.name, new_name = name)
      result = BuildServer.clone_platform new_name, old_name, APP_CONFIG['root_path'] + '/platforms'
      if result == BuildServer::SUCCESS
        return true
      else
        raise "Failed to clone platform #{old_name} with code #{result}. Path: #{build_path(old_name)} to platform #{new_name}"
      end
    end
    later :xml_rpc_clone, :loner => true, :queue => :clone_build

    def freeze_platform_and_update_repos
      if released_changed? && released == true
        result = BuildServer.freeze(name)
        raise "Failed freeze platform #{name} with code #{result}" if result != BuildServer::SUCCESS
        repositories.update_all(:publish_without_qa => false)
      end
    end
end
