# Handle changes to JIRA-like tasks
module.exports = (unseenPaths) ->
  for path in unseenPaths
    parents = path.slice(0, path.length - 1)
    text = path.slice(path.length - 1)[0]

    issue = buildIssue text
    continue if not issue
    handle issue, parents


# todo: send updates to the JIRA API
handle = (issue, parents) ->
  console.log issue


# creates an issue object from its text shorthand
# todo: get additional info for an issue from the JIRA API
buildIssue = (text) ->
  match = /^(.+)\s*\(((\w+)-(new|\d+))(?:\s*,(.+))?\)$/i.exec text
  return null if not match

  issue =
    localTitle: match[1].trim()
    issueKey: match[2]
    projectKey: match[3]

  issue.exists = match[4] != "new"
  if issue.exists
    issue.issueId = parseInt(match[4], 10)

  attrs = if match[5] then (attr.trim() for attr in match[5].split(",")) else []

  # parse out attributes of the issue
  for attr in attrs
    if match = /(\d+)sp/i.exec attr
      issue.storyPoints = parseInt(match[1], 10)
    else if match = /(\d+h)\/(\d+h)/i.exec attr
      issue.estimate =
        completed: match[1]
        total: match[2]
    else if match = /@(\w+)/.exec attr
      issue.assignee = match[1]

  return issue
