# static-sticky

[static-sticky] is our public website, which can be viewed at <svsticky.nl>.

The website is build in GitHub Actions.
The content of the site lives in [Contentful].
When the content changes, Contentful throws a webhook at GitHub Actions, and the build is triggered.
The same happens when a commit is pushed to master.
If the build succeeds, it is pushed to [Amazon S3].
Then a webhooks is thrown to [Aas], which should also be deployed to the same server.

This role sets up a script that fetches the latest build from S3.
A systemd service then runs this script.
This systemd service is started once on deploy, and should after that be started by Aas.

A Nginx configuration is set up that not only serves the website,
but also falls back to our link shortener, [doorgeefluik] when that fails.

[Aas]:https://github.com/svsticky/aas
[static-sticky]:https://github.com/svsticky/static-sticky
[Contentful]:https://www.contentful.com/
[Amazon S3]:https://aws.amazon.com/s3/
[doorgeefluik]:https://github.com/svsticky/doorgeefluik/
