Configuration.new do
  fission do
    sources do
      mail.type 'actor'
      test.type 'spec'
    end

    workers.mail 1

    loaders do
      workers ['fission-mail/mandrill']
      sources ['carnivore-actor']
    end

    # TODO, set me to something fixed after initial testing
    mandrill.api_key 'abc123'
  end
end
