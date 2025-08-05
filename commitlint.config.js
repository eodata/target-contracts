module.exports = {
  extends: ["@commitlint/config-conventional"],
  ignores: [(commitMessage) => commitMessage.startsWith("Merge")],
};
