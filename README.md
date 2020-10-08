# GitHub Dashboard

GitHub Dashboard is front end to the GitHub repository providing a dashboard which indicates the state of various actions.

### GitHub Configuration
The dashboard needs to have three environment variables set:
- GITHUB_KEY
- GITHUB_SECRET
	The combination of GITHUB_KEY (client_id) and GITHUB_TOKEN  (client_secret) provide access to the Github single sign on pages. The application needs to be registered via the [GitHub OAuth application settings](https://docs.github.com/en/free-pro-team@latest/developers/apps/authorizing-oauth-apps)
- GITHUB_TOKEN
	This is an [authorization token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/connecting-to-github-with-ssh) provided by GitHub granting the bearer access to the repositories . If the repositories are publicly available this would not necessarily be needed, except that without it GitHub limits the number of API calls you can make in a period.

###	Execution
The application has been written using Ruby rails, and can be simply started with:

    rails s

#### Options
To improve query performance a the ability to cache to REDIS has been provided. If there is a REDIS server on the default connection redis://127.0.0.1:6379 then this will be used.
It is possible to override this by using the environment variable REDIS_URL

    export REDIS_URL=redis://127.0.0.1:6379

### Configuration
The file config/settings.yml controls what is shown:

---

    title:
      name: "Dashboard Title"
    
    projects:
     - api:
       ref:       "<Owner>/<Repository>"
       name:      "Name of Repository"
       environments:
          - name: "Name of First Environment"
            deployment_workflow: "Build and Deploy"
            deployment_branch:   "master"
            releases:
                 allowed: false
          - name: "Name of Second Environment"
            deployment_workflow: "Release to Test"
            graph:
               max_time: 2000
          - name: "Name of Third Environment"
            deployment_workflow: "Release to Production"
