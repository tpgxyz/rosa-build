json.platform do |json|
  json.partial! 'platform', :platform => @platform, :json => json
  json.(@platform, :description, :parent_platform_id, :released, :visibility, :platform_type, :distrib_type)
  json.created_at @platform.created_at.to_i
  json.updated_at @platform.updated_at.to_i
  json.partial! 'api/v1/shared/owner', :owner => @platform.owner
  json.repositories @platform.repositories do |json_repos, repo|
    json_repos.(repo, :id, :name)
    json_repos.url api_v1_repository_path(repo.id, :format => :json)
  end
end