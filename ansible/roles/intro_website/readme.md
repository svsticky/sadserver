# Intro website

[intro-website] is our public website, which can be viewed at <intro.svsticky.nl>.

The website is build in GitHub Actions.
The content of the site lives in [Contentful].
When the content changes, Contentful throws a webhook at GitHub Actions,
and the build is triggered.
The same happens when a commit is pushed to the main or development branch.
If the build succeeds, it is published as an artifact on GitHub.
The build consists of static files which can simply be served by nginx.
Once the artifact has been published, a webhook is thrown to [Aas], which should
also be deployed to the same server.
Aas will then trigger a systemd service deployed by this role, which downloads
the correct artifact, extracts it and replaces the current files on the server.
Once all files are replaced, the new version of the website has been deployed.

This systemd service is started once on deploy as well.

A Nginx configuration is set up that not only serves the website,
but also falls back to our link shortener, [doorgeefluik] when that fails.

In short, this role thus simply makes it possible to statically serve some
files, which are hosted on GitHub.
Once a new version of the website is available (or during manual deploy), these
files are updated.

[Aas]:https://github.com/svsticky/aas
[intro-website]:https://github.com/svsticky/intro-website
[Contentful]:https://www.contentful.com/
[doorgeefluik]:https://github.com/svsticky/doorgeefluik/
