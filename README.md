How not to mess things up while setting up Swapidy from scratch:
I'm assuming you would be able to clone the file on your computer.
I'm controlling versioning using rvm. Its great.
Now time to hook heroku so that you can deploy

1) Send an email to PJ (pulkit@swapidy.com) and he'll add you as a collaborator.
2) Read https://devcenter.heroku.com/articles/quickstart and learn how to login using cl/terminal.
3) Now, run git remote add heroku git@heroku.com:swapidy-test.git
4) Acid test: try git remote and if you see heroku along with origin, you're good. Otherwise you can look up stuff on stackoverflow and theres extensive documentation.
5) Congrats if you made it this far. Now remember to always git fetch --all before git push heroku master

Everytime you pull, make sure you run the db initialization script: rake swapidy:db:reset

If you don't see any js function getting executed, you should run rake assets:precompile

[1/2/13 10:31:05 PM] Thanh Hai (Viet - Scrum2B): I create another branch: master-dev

[1/2/13 11:06:13 PM] Thanh Hai (Viet - Scrum2B): Hi all, I explain about the git branches in GitHUb
[1/2/13 11:06:20 PM] Thanh Hai (Viet - Scrum2B): there are 3 branches:
[1/2/13 11:06:26 PM] Thanh Hai (Viet - Scrum2B): 1. develop
[1/2/13 11:06:32 PM] Thanh Hai (Viet - Scrum2B): 2. master-dev
[1/2/13 11:06:35 PM] Thanh Hai (Viet - Scrum2B): 3. master
[1/2/13 11:07:20 PM] Thanh Hai (Viet - Scrum2B): everyone should work on develop branch firstly:
[1/2/13 11:07:38 PM] Thanh Hai (Viet - Scrum2B): git checkout -b develop origin/develop
[1/2/13 11:08:07 PM] Thanh Hai (Viet - Scrum2B): git checkout develop (for person who run the above command before)
[1/2/13 11:08:13 PM] Thanh Hai (Viet - Scrum2B): Every commits in development will be pushed into develop branch:
[1/2/13 11:08:29 PM] Thanh Hai (Viet - Scrum2B): git commit -a -m "Comment description"
[1/2/13 11:08:37 PM] Thanh Hai (Viet - Scrum2B): git push origin develop
[1/2/13 11:09:27 PM] Thanh Hai (Viet - Scrum2B): For testing in swapidy-dev.herokuapp.com, we need to push the commits into master-dev
[1/2/13 11:09:36 PM] Thanh Hai (Viet - Scrum2B): git checkout master-dev
[1/2/13 11:09:42 PM] Thanh Hai (Viet - Scrum2B): git merge develop
[1/2/13 11:10:07 PM] Thanh Hai (Viet - Scrum2B): git merge heroku-dev/master
[1/2/13 11:10:18 PM] Thanh Hai (Viet - Scrum2B): git push heroku-dev master-dev:master
[1/2/13 11:11:00 PM] Thanh Hai (Viet - Scrum2B): After testing all works run well in swapidy-dev.herokuapp.com, we will merge codes into live site (swapidy.com):
[1/2/13 11:11:09 PM] Thanh Hai (Viet - Scrum2B): git checkout master
[1/2/13 11:11:20 PM] Thanh Hai (Viet - Scrum2B): git merge heroku/master
[1/2/13 11:11:51 PM] Thanh Hai (Viet - Scrum2B): git merge develop
[1/2/13 11:11:59 PM] Thanh Hai (Viet - Scrum2B): git push heroku master
[1/2/13 11:12:33 PM] Thanh Hai (Viet - Scrum2B): For overall, codes will go from: develop -> master-dev -> master
[1/2/13 11:12:56 PM] Thanh Hai (Viet - Scrum2B): develop for everything we work
[1/2/13 11:13:01 PM] Thanh Hai (Viet - Scrum2B): master-dev for testing
[1/2/13 11:13:06 PM] Thanh Hai (Viet - Scrum2B): master for livesite
