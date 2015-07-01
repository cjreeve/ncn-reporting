json.array!(@problems) do |problem|
  json.extract! problem, :id, :name
  json.url problem_url(problem, format: :json)
end
