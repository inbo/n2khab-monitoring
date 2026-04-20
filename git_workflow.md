# Git workflow

This document lists conventions for the standard Git workflow that applies to the involved repositories.

General aspects of Git workflows that are generally followed too:

- Git workflows at INBO: <https://inbo.github.io/tutorials/tags/git/>.
See also [these Git workshop materials](https://inbo.github.io/git-course/index.html).
- the [GitHub flow](https://guides.github.com/introduction/flow/)

Several frontends for Git can do the job (or some part of it), and you can use [Git](https://git-scm.com/) in full on the command line.

Here we add some specific conventions.


## Commit messages: specific, concise and topical

### Specific

Commits have a commit message, which is composed of a message title and an optional message body (separated from the title by a whiteline).

- The 'what' and (if not already clear) 'why' is generally what you want to convey in a commit message.
- Try to describe the activity, not the result of the commit.
An activity is 'add a', 'fix b', 'update c to get d right', etc.; prefixed with 'topic: ' as shown below.
- In general, try to be specific, in order to avoid multiple commits with the same message.

### Concise

At the same time, let the message title not exceed 72 characters (shorter is better: 50 is often recommended), otherwise it can be truncated in certain views, e.g. in GitHub.
To avoid this and still be specific, use abbreviations (make custom ones); if needed, refer to a message body with more information (see below).
Also let the message body itself not be wider than 72 characters, as some views will wrap longer lines.

### Topical

Commits are snapshots of the whole repository, even though the work they represent is often a tiny element of the repo.
The commit history (e.g. `git log --oneline`) shows at least the commit message titles.

The messages should consider the _repo_ point of view, by making explicit which _topic_ (part, project, theme, ...) within the repo is being addressed.

This way, the messages are self-explanatory from a repo point of view.
This is relevant when looking at the commit history of a repository.

This is the format we use:

    topic: do this

    topic, subtopic: do this

```
topic: do that *

Optional extra information below a whiteline is the message body: it is shown in the full log message,
but not in oneline log message output = reason to add the '*' at the end of the message title

These can even be multiple paragraphs. You can use this to motivate a change you made to future-you and other collaborators;
it often makes sense to do this in the commit message rather than in a report itself if that historical information will be superfluous for readers.
```

There may be commits where the update is relevant to the whole repo (e.g. updating a file with repo-wide scope).
When multiple files are affected, a 'topic: ' format will generally not be applicable.
If it's just a single file then it is still recommended to use e.g. `.zenodo.json: update repo URL` (where `.zenodo.json` is a filename).
This way, similar updates will be spotted more easily [^follow].

[^follow]: Use the `--follow` option of `git log` if you want to effectively filter the commit history with regard to changes of a specific file, including renames, regardless of the commit message.


## Branching: one person (maintainer) per branch

Make commits (in your local clone of the remote repo on Github) _in your own git branch_, branched off from the **base** branch you wish to contribute to -- below referred as `<base>` branch.
Let's call your new branch the `<feature>` branch.
This relation is relative: someone else may want to contribute to _your_ branch, so that for that person your feature branch is her/his base branch, and so on.

### Maintainership

Starting a branch makes you the **maintainer** of the branch, unless agreed otherwise.
As a maintainer, you will decide on and execute the merges of (other) feature branches that target your branch as their 'base branch' in a pull request.

In the `main` branch (or sometimes: a common development branch with repo-wide scope), multiple maintainers may co-exist, but then we still divide maintainership based on the (sub)directory, where one person is maintainer for one (sub)directory.
Ideally we make this transparent and even appoint a backup maintainer who can take over when something can't wait.

### Pushing to the remote

You _can_ push your branch to the remote 'as often as you like', as it will not influence other branches (first time: do `git push -u origin yourbranchname`; afterwards `git push` suffices).
It serves as a backup and enables others to work with you on that branch.

Still, it's recommended to not push each commit immediately when you expect to add more commits.
This is especially the case in pull requests (see: pull requests; rewriting history).

Further, keep your branch up to date with evolutions in the base branch as needed, by doing a local merge of the base branch in the feature branch.
This may be necessary to ensure a smooth merge of your branch to the base branch later on.

- The easiest way is `git pull origin <base>` while having your feature branch checked out.
- If you also wish to update your local base branch in this process, you can first `git switch <base>` followed by `git pull`, then switch back to `git switch <feature>` and merge the base branch into the feature branch with `git merge --no-ff <base>`.

If any merge conflicts arise at this stage, resolve them in your own branch.
To do this, first fix the files with conflicts, then stage them `git add` and conclude the merge commit with `git commit`.


## Merging via pull request versus locally merging

In general we use a **pull request** [^pr] to merge the feature branch into the base branch.
(On the contrary, merging the base branch into the feature branch to keep up to date with the base branch or to fix conflicts, is done locally in the feature branch: see above.)

[^pr]: Note that the term 'pull request' is used by GitHub, but the logical name should be 'merge request', as used by some others.

There is a situation where the pull request is not necessary: if the base branch is not `main` (or a common development branch everybody is merging to) _and_ you are the maintainer of the involved code in the base branch (i.e. the feature just updates it) _and_ you don't need collaboration with or reviewing by a colleague before merging.
In this case it's perfectly OK to work locally and do the merge with `git switch <base> && git merge --no-ff <feature>`.

In all other cases however we use a pull request.
In the simplest case where no review is needed (you maintain already existing, corresponding code in `main`), this generates notifications for collaborators so they then know that the `<base>` branch is evolving.


## Pull request workflow

Make sure to correctly **set the base branch** in the pull request (because the default is typically `main`).

### Pushing commits in a pull request

After starting a pull request, you can keep pushing new commits to the feature branch as long as the pull request is not merged.

With a pull request active, each push to the feature branch generates a notification for collaborators.
So if it's not needed to push commits one by one, then it's great if multiple commits are combined in one push, especially in the case of pull requests.
On the other hand don't wait too long, since the remote serves as a backup for your work, and maybe others need to use your results immediately (this is less common though).

Strive to push your (finished) commits at least once a day.

### When to start the pull request

You can start a pull request when your ongoing work is relevant for collaborators (so they get notifications), to make it possible to post (additional) explanation in the online pull request or to allow online discussions about your changes. Each online message also triggers notifications.
A pull request is _needed_ from the moment you want an (online, open) review of your changes, and/or when you want to have your changes merged.

### Optionally use a draft pull request

For work-in-progress: if you want to avoid that a maintainer can merge your branch (by not realizing more is still coming), make the pull request a 'draft pull request'.
A draft pull request in GitHub still has all other functionality of a normal pull request, including reviewing.

### Commits in response to reviews

A review may lead to more commits, some of which can be done online based on commit suggestions by the reviewer.
Best apply commit suggestions first (can also be done in batches, e.g. all typos) if you want to adopt them, since they may become non-functional after pushing regular new commits (conflicts may arise with the suggestion, so that you need to redo them locally anyway).

If you need another review after you commited changes following a previous review, you can use the 'Re-request review' button, but do it responsibly (see further).

After your PR is merged, pull the base branch and clean up your local repo in order to keep up with the remote (see below).


## Reviewing versus merging

### To review or not to review

A review is _needed_ when the code (directory) you are contributing to (in the base branch) is not under your own maintenance.

If that code in the base branch _is_ under your own maintenance, the need for review depends on the situation.
Specific expectations on this may already exist, possibly depending on the impact of changes.
We place trust in your judgment, but do ask in case of doubt, before merging yourself.

If asking for a review, please also take into account the time that a reviewer would need to spend on it:

- Did the reviewer expect this?
- Was it foreseen that this person would (now?) do this review?
- How much time would it take? Don't underestimate the time a more thorough review may take; multiple iterations may be needed.

In case of doubt, it's best to talk this through before just 'ordering a review' from a person in GitHub.

### Who reviews?

The reviewer is **a person who can** make relevant suggestions in the context of the set goals or requirements.
The reviewer does not have to be the maintainer of code in the base branch.
If the reviewer is not the maintainer, it's still important to communicate with the maintainer about the intended process, since (s)he decides whether and when to merge.

### Who merges?

This is sometimes a source of confusion in collaborative settings, but here it's straightforward.
Merging is always done by the **maintainer of the base branch**, or by the maintainer of that particular code in the base branch if the base branch has multiple maintainers (applies to `main` or perhaps a common development branch with repo-wide scope).

The maintainer may also decide that a review is still needed by either the maintainer or someone else, before doing the merge.
Alternatively, the maintainer can consider the base branch as 'work in progress', perform the merge already but keep track of the fact that further reviewing or updating is still needed (e.g. by making an issue).
This all depends on the nature and purpose of the base branch.


## Avoid rewriting history in the remote

Co-workers need to be able to push and pull easily.
When the commit history of a branch is rewritten in the remote (with a force-push), this causes diverging local and remote-tracking branches for co-workers, hence this poses extra challenges for them when they are collaborating on that branch.

Furthermore, existing (manual) referrals to commit hashes (including within commit messages) will become out-of-date, which is annoying.

### General rules

For the above reasons:

- Avoid force-pushes.
- Make updates of already pushed code by adding new commits.

These general rules will avoid the above problems.

### Reasons for rewriting local history

Still, various reasons may exist to update (usually recent) commit history:

- (A) Removing information that poses a threat to e.g. privacy or security.
- (A) Removing unintentionally committed large files.
- (B) Fixing a bad or misleading commit message.
- (C) Keeping commits coherent (different things being addressed by different commits).
- (C) Fixing a bug in the code.

As long as the involved commits were _not pushed_ to the remote, all these reasons are OK to rewrite local history and make the commit history more accessible.
See also the advice before about not pushing commit by commit, especially in pull requests, if that is not needed.

### Force-pushing

If however the involved commits have been pushed already, only situation A is really essential and justify force-pushing.

For reasons B and C, it depends on the impact you will cause.
Also, B is more relevant than C, as it causes confusion or misunderstanding.

The fact that direct commits to a single branch are only done by you as the branch's maintainer allows for some nuance.
For B and C, it depends on:

- whether you are pushing to a pull request (generating notifications, and possibly triggering others to use or review your code)
- the time elapsed between original commits and intended refactored commits
- whether co-workers are actively working on the same code, 'downstream' (i.e. based on your branch)

Recommendations for B and C:

- Best limit your consideration to the really 'worthwile' updates (minor details are not important).
- **In pull requests**, force-pushing creates more disturbance because of collaboration and notifications.
    - Never do it for situation C!
    - Only _consider_ force-pushing for **situation B**, but don't do it if too much time has elapsed (e.g. several hours, depending on the frequency of collaboration) and also avoid it if the commit message was not 'too bad'.
    You want to avoid that co-workers are impacted that already work with the original state (by fetching code or reviewing code).
    If too much time has elapsed, you can still post a message in the pull request to point at the inconvenience, for future reference.
    - If you effectively do a force-push in a pull-request, notify co-workers by posting a small message in the pull request!
- **Outside of pull requests**, no notifications are triggered by GitHub.
    - You can consider **both reasons B and C**, but also here take into account the potential impact for co-workers, depending on the lag and on aspects of collaboration.
  Communicate with co-workers as needed, of if in doubt.
    - Still the general rule applies; avoid force-pushing if the benefit is too small and if impact on co-workers would be real.


## Recommendations in managing local branches

This can be extended.
Some hints:

- To update the remote-tracking branches (these are stored in the local repo):

    git fetch -p
    
- To show the local branches, their remote-tracking counterpart and sync state:
    
    git branch -vv # 
    
- To pull (i.e. fetch and merge) the remote-tracking branch in the local branch:

    git switch <branch>
    git pull
    
- To delete a local branch; will error if not merged locally:

    git branch -d <branch>
    
- To delete a local branch anyway; use with caution:

    git branch -D <branch>


## Some Git resources

- Günther T. (2014). Learn version control with Git: A step-by-step course for the complete beginner.
- <https://learngitbranching.js.org/>
- [Interactive Git cheatsheet](http://ndpsoftware.com/git-cheatsheet.html)
