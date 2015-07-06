class JiraRestExtractor < BaseExtractor
  def extract(collection, endpoint)
    query = collection.extract.params.query
    puts "query: #{query}"
    options = {
      username: endpoint.username,
      password: endpoint.password,
      site: endpoint.site,
      context_path: endpoint.context_path,
      auth_type: endpoint.auth_type,
      use_ssl: endpoint.use_ssl
    }
    client = JIRA::Client.new(options)

    cache = {}

    puts 'fetching...'
    output = []
    chunk_size = 100
    start_at = 0
    i = 0
    loop do
      start_at = i * chunk_size
      puts 'chunk %04d: %05d-%05d' % [i, start_at, start_at + chunk_size - 1]
      result = []
      Retriable.retriable on: JIRA::HTTPError, tries: 3, interval: 10 do
        result = client.Issue.jql(query, ['*all', 'worklog'], start_at, chunk_size).map do |issue|
          doc = {}
          doc['key'] = issue.key
          doc['id'] = issue.id
          doc['fields'] = issue.fields

          #
          # Extension 1. Expand worklogs
          #
          worklogs = []
          worklogs_stored = issue.fields['worklog']['total']
          worklogs_returned = issue.fields['worklog']['maxResults']

          # Do we need to fetch all the worklogs?
          if worklogs_stored > worklogs_returned
            # puts "Fetching worklogs for #{issue.key}"
            worklogs = issue.all_worklogs.map { |wl| JSON.parse wl.to_json }
          else
            worklogs = issue.fields['worklog']['worklogs']
          end
          fail 'Failed to fetch all the worklogs' unless worklogs_stored == worklogs.length

          #
          # Extension 2. Expand parent
          #
          parent = nil
          if issue.has_parent?
            parent_key = issue.fields['parent']['key']
            if cache.key?(parent_key)
              puts 'Parent cache hit'
              parent = cache[parent_key]
            else
              puts 'Fetching parent'
              parent = issue.parent
              cache.store(parent_key, parent)
            end
            parent = JSON.parse(parent.to_json)
          end

          #
          # Extension 3. Expand epic_link
          #
          linked_epic = nil
          if issue.has_linked_epic?
            epic_key = issue.linked_epic_key
            if cache.key?(epic_key)
              puts 'Epic cache hit'
              linked_epic = cache[epic_key]
            else
              puts 'Fetching epic'
              linked_epic = issue.linked_epic
              cache.store(epic_key, linked_epic)
            end
            linked_epic = JSON.parse(linked_epic.to_json)
          end

          doc['_extensions'] = { worklogs: worklogs, parent: parent, linked_epic: linked_epic }

          doc
        end
      end
      break if result.empty?
      output = output.concat(result)
      break if result.length < chunk_size
      i += 1
    end
    puts "cache size #{cache.length}"
    puts "fetched #{output.length} docs"
    output
  end
end
