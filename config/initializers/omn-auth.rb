Rails.application.config.middleware.use OmniAuth::Builder do
    OMNI_KEY="f02fb82d8c6b24353e3f"
    OMNI_SECRET="f3da8ef10acf6276d160c90d31f075b684299938"
    provider :github, OMNI_KEY, OMNI_SECRET, scope: "user:email,user:follow"
    # provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: "user:email,user:follow"
end