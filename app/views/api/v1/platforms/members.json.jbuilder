json.platform do |json|
  json.(@platform, :id)
  json.members @members do |json_members, member|
    json_members.(member, :id)
    json_members.type member.class.name
    json_members.url member_path(member)
  end
end
json.url members_api_v1_platform_path(@platform.id, :format => :json)