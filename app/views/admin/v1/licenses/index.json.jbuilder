json.licenses do
  json.array! @loading_service.records, :id, :key, :status, :platform, :game_id
end

json.meta do
  json.partial! 'shared/pagination', pagination: @loading_service.pagination
end
