require 'csv'
require "open-uri"
namespace :maps do
  desc "Setup maps from pre defined files"
  task seed: [:environment] do
    puts "Start maps seed"

    if Map.count < 4000
      puts "Start maps seed from ref files"
      ActiveRecord::Base.connection.drop_table 'maps_ref_states' if ActiveRecord::Base.connection.table_exists? 'maps_ref_states'
      ActiveRecord::Base.connection.drop_table 'maps_ref_ac' if ActiveRecord::Base.connection.table_exists? 'maps_ref_ac'
      ActiveRecord::Base.connection.drop_table 'maps_ref_pc' if ActiveRecord::Base.connection.table_exists? 'maps_ref_pc'

      OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

      pc_maps = 'https://www.strongspace.com/shared/69ellg1pvo'
      ac_maps = 'https://www.strongspace.com/shared/e03ew1czbo'
      state_maps = 'https://www.strongspace.com/shared/bh4yt2zc3p'

      ActiveRecord::Base.connection.execute(URI.parse(pc_maps).read)
      ActiveRecord::Base.connection.execute(URI.parse(ac_maps).read)
      ActiveRecord::Base.connection.execute(URI.parse(state_maps).read)

      ActiveRecord::Base.connection.execute "
      TRUNCATE TABLE maps;
      INSERT INTO maps(name, shape, kind, created_at, updated_at)
        select st_nm, geom, 'state', current_timestamp, current_timestamp from maps_ref_states;
      INSERT INTO maps(name, state_code, shape, kind, created_at, updated_at)
        select pc_name, LOWER(st_name), geom, 'parliamentary', current_timestamp, current_timestamp from maps_ref_pc;
      INSERT INTO maps(name, state_name, shape, kind, created_at, updated_at)
        select ac_name, LOWER(st_name), geom, 'assembly', current_timestamp, current_timestamp from maps_ref_ac;
      UPDATE maps
        SET name = REPLACE(name, '&', 'and');
      UPDATE maps
        SET state_name = REPLACE(state_name, '&', 'and');
      "

      Map.where(name: nil).destroy_all

      puts "Sanitizing names"
      map_names = {}
      Map.where(mappable_id: nil).find_each do |map|
        name = map.name.downcase.gsub(/\([a-zA-Z]*\)/, '').strip
        map.name = name
        map_names[map.id] = name
      end
      map_names.each_pair do |key, value|
        puts "Map key value pair is #{key}-#{value}"
        ActiveRecord::Base.connection.execute(<<-EOQ)
      UPDATE  maps SET name='#{value}' where id='#{key}'
    EOQ
      end

      Map.where(name: "andaman and nicobar island").update_all(name: 'andaman and nicobar islands')
      Map.where(name: "dadara and nagar havelli").update_all(name: 'dadra and nagar haveli')
      Map.where(name: "nct of delhi").update_all(name: 'delhi')
      Map.where(name: "odisha").update_all(name: 'orissa')
      Map.where(name: "arunanchal pradesh").update_all(name: 'arunachal pradesh')
      Map.where(name: "uttarkhand").update_all(name: 'uttarakhand')
      Map.where(state_name: "uttarkhand").update_all(state_name: 'uttarakhand')

      puts "Start maps seed from ref files"
    end

    puts "Wiring states and constituencies"

    mappables = {}

    Map.where(mappable_id: nil).find_each do |map|
      case map.kind
      when 'state'
        mappable = CountryState.find_by_name(map.name)
        if mappable
          mappables[map.id] = {
            type: 'CountryState',
            id: mappable.id
          }
        end
      else
        country_state = if map.state_name
                          CountryState.find_by_name(map.state_name)
                        else
                          CountryState.find_by_code(map.state_code)
                        end

        if country_state
          constituency = country_state.constituencies.where(name: map.name, kind: map.kind).first

          if !constituency && country_state.code == 'ap'
            constituency = CountryState.find_by_code('ts').constituencies.where(name: map.name, kind: map.kind).first
          end

          if constituency
            mappables[map.id] = {
              type: 'Constituency',
              id: constituency.id
            }
          end
        end
      end
    end

    mappables.each_pair do |key, value|
      query = <<-EOQ
        UPDATE  maps SET mappable_id='#{value[:id]}', mappable_type='#{value[:type]}' where id='#{key}'
      EOQ
      ActiveRecord::Base.connection.execute(query)
      puts "Mappable is #{key}-#{value}"
    end
  end
end
