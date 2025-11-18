context do
  namespace "bin" do
    file "bin/ghr_update_config", tags: [ 'bin', 'update', 'backup', 'restore' ]
  end

  namespace "lib" do
    Dir['app/**/*.rb'].each do |filename|
      file filename, tags: 'app'
    end
  end

  namespace "spec" do
    Dir['spec/**/*.rb'].each do |filename|
      file filename, tags: 'spec'
    end
  end

  file '.contexts/yard.md', tags: [ 'yard', 'cheatsheet' ]

  file 'config/ghr_config.rb', tags: [ 'configuration', 'app', 'example' ]
end
