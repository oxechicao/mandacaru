#/bin/bash

scope=$1
context_file=$2

git add .
gdiff=$(git diff)

prompt=$(
  cat <<END_STRING
Read this diff:
$gdiff

Read the file $context_file to get more context about the feature.

No Comentaries, only the commit message.

DO:
Write a commit message that follows the conventional commit format.
The subject should be limited in 50 characters, and the body should be limited in 72 characters.
The subject in the first line should be a concise summary.
The scope that should be used in the subject is $scope.
Do a summary of changes before the sections.
Write the changes in sections.
Write a detailed list of changes for each section, with bullet points. Use hiphens.
Add one line before each section title.
Output only the commit message.

DO NOT:
Do not use markdown syntax.
No add blank lines after section title.
Do not add any comentaries or explanations
END_STRING
)

message=$(codex exec "$prompt")

git commit -m "$message"
