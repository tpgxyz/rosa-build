# -*- encoding : utf-8 -*-
class Git::TreesController < Git::BaseController
  def show
    redirect_to project_path(@project) and return if params[:treeish] == @project.default_branch and params[:path].blank?

    @path = params[:path]
    @tree = @git_repository.tree(@treeish)
    @branch = @project.branch(@treeish)

#    @commit = @git_repository.commits(@treeish, 1).first
#   Raises Grit::Git::GitTimeout
    @commit = @branch.present? ? @branch.commit() : @git_repository.log(@treeish, @path, :max_count => 1).first
    render :template => "git/trees/empty" and return unless @commit

    @tree = @tree / @path if @path
    render :template => "git/trees/show"
  end

  def archive
    treeish = params[:treeish].presence || @project.default_branch
    format = params[:format] || 'tar'
    commit = @project.git_repository.log(treeish, nil, :max_count => 1).first
    name = "#{@project.owner.uname}-#{@project.name}#{@project.tags.include?(treeish) ? "-#{treeish}" : ''}-#{commit.id[0..19]}"
    fullname = "#{name}.#{format == 'tar' ? 'tar.gz' : 'zip'}"
    file = Tempfile.new fullname, 'tmp'
    system("cd #{@project.path}; git archive --format=#{format} --prefix=#{name}/ #{treeish} #{format == 'tar' ? ' | gzip -9' : ''} > #{file.path}")
    file.close
    send_file file.path, :disposition => 'attachment', :type => "application/#{format == 'tar' ? 'x-tar-gz' : 'zip'}",
      :filename => fullname
  end

end
