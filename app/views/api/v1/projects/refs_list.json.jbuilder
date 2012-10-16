json.refs_list (@project.repo.branches + @project.repo.tags) do |json_grit, grit|
  json_grit.ref grit.name
  json_grit.object do |json_object|
    json_object.type (grit.class.name =~ /Tag/ ? 'tag' : 'commit')
    json_object.sha grit.commit.id
  end
end
json.url refs_list_api_v1_project_path(@project.id, :format => :json)