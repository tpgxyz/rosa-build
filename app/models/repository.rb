class Repository < ActiveRecord::Base
  belongs_to :platform
  has_many :projects, :dependent => :destroy

  validates :name, :uniqueness => {:scope => :platform_id}, :presence => true
  validates :unixname, :uniqueness => {:scope => :platform_id}, :presence => true, :format => { :with => /^[a-zA-Z0-9\-.]+$/ }

  scope :recent, order("name ASC")

  before_create :xml_rpc_create
  before_destroy :xml_rpc_destroy

  def path
    build_path(unixname)
  end

  def clone
    r = Repository.new
    r.name = name
    r.unixname = unixname
    r.projects = projects.map(&:clone)
    return r
  end

  protected

    def build_path(dir)
      File.join(platform.path, dir)
    end

    def create_directory
      exists = File.exists?(path) && File.directory?(path)
      raise "Directory #{path} already exists" if exists
      if new_record?
        FileUtils.mkdir_p(path)
        %w(release updates).each { |subrep| FileUtils.mkdir_p(path + subrep) }
      elsif unixname_changed?
        FileUtils.mv(build_path(unixname_was), buildpath(unixname))
      end 
    end
    
    def xml_rpc_create
      result = BuildServer.create_repo unixname, platform.unixname
      if result == BuildServer::SUCCESS
        return true
      else
        raise "Failed to create repository #{name} inside platform #{platform.name}."
      end      
    end

    def xml_rpc_destroy
      result = BuildServer.delete_repo unixname, platform.unixname
      if result == BuildServer::SUCCESS
        return true
      else
        raise "Failed to delete repository #{name} inside platform #{platform.name}."
      end
    end

end
