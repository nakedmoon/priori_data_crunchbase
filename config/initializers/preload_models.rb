Dir[Rails.root + 'app/models/*.rb'].map {|f| File.basename(f, '.*').camelize.constantize }
