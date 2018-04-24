namespace :constituencies do
  desc "Generate maps images for assembly constituencies of given state"
  task :generate_state_assembly_constituency_images, [:state_code] => [:environment] do |_task, args|
    puts "Scale up image maker"
    HerokuClient.scale_up_image_maker
    puts "~" * 80
    cs = CountryState.find_by_code!(args[:state_code])
    cs.constituencies.assembly.each do |assem|
      puts "~" * 80
      puts "Assembly name #{assem.name}"
      generated = assem.generate_image(true)
      puts "Complete generating image - succeeded? #{generated}"
      puts "~" * 80
    end
    puts "Scale down image maker"
    HerokuClient.scale_down_image_maker
  end

  desc "Generate maps images for parliamentary constituencies of given state"
  task :generate_state_parliamentary_constituency_images, [:state_code] => [:environment] do |_task, args|
    puts "Scale up image maker"
    HerokuClient.scale_up_image_maker
    puts "~" * 80
    cs = CountryState.find_by_code!(args[:state_code])
    cs.constituencies.parliamentary.each do |assem|
      puts "~" * 80
      puts "Parliamentary name #{assem.name}"
      generated = assem.generate_image(true)
      puts "Complete generating image - succeeded? #{generated}"
      puts "~" * 80
    end
    puts "Scale down image maker"
    HerokuClient.scale_down_image_maker
  end

  desc "Generate maps images across india"
  task generate_map_images_for_all: [:environment] do |_args|
    puts "~" * 80
    CountryState.all.each do |cs|
      puts "Start on assembly constituency #{cs.name}"
      Rake::Task["constituencies:generate_state_assembly_constituency_images"].invoke(cs.code)
      Rake::Task["constituencies:generate_state_assembly_constituency_images"].reenable
      puts "End on assembly constituency #{cs.name}"
      puts "=" * 80

      puts "Start on parliamentary constituency #{cs.name}"
      Rake::Task["constituencies:generate_state_parliamentary_constituency_images"].invoke(cs.code)
      Rake::Task["constituencies:generate_state_parliamentary_constituency_images"].reenable
      puts "End on parliamentary constituency #{cs.name}"
      puts "=" * 80
    end
  end

  desc "Generate maps meta data"
  task generate_map_meta: [:environment] do |_args|
    puts "~" * 80
    Constituency.all.each do |const|
      puts "Start on constituency #{const.name}"
      const.generate_map_meta
      puts "End on constituency #{const.name}"
      puts "=" * 80
    end
  end

  desc "Generate bounding boxes"
  task states_generate_map_meta: [:environment] do |_args|
    puts "~" * 80
    CountryState.all.each do |cs|
      puts "Start on state #{cs.name}"
      cs.generate_map_meta
      puts "End on state #{cs.name}"
      puts "=" * 80
    end
  end
end
