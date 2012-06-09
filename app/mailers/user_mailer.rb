# -*- encoding : utf-8 -*-

class UserMailer < ActionMailer::Base
  default :from => APP_CONFIG['do-not-reply-email']

  include Modules::Models::ResqueAsyncMethods

  @queue = :notifications

  def new_user_notification(user)
    @user = user
    mail(:to => user.email, :subject => I18n.t("notifications.subjects.new_user_notification", :project_name => APP_CONFIG['project_name'])) do |format|
      format.html
    end
  end

  def new_comment_notification(comment, user)
    @user = user
    @comment = comment
    mail(:to => user.email, :subject => I18n.t("notifications.subjects.new_#{comment.commit_comment? ? 'commit_' : ''}comment_notification")) do |format|
      format.html
    end
  end

  def new_issue_notification(issue, user)
    @user = user
    @issue = issue
    mail(:to => user.email, :subject => I18n.t("notifications.subjects.new_issue_notification")) do |format|
      format.html
    end
  end

  def issue_assign_notification(issue, user)
    @user = user
    @issue = issue
    mail(:to => user.email, :subject => I18n.t("notifications.subjects.issue_assign_notification")) do |format|
      format.html
    end
  end

  def invite_approve_notification(register_request)
    @register_request = register_request
    mail :to => register_request.email, :subject => I18n.t("notifications.subjects.invite_approve_notification")
  end
end
