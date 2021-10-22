use WebService::GitHub::Role;
unit class WebService::GitHub::GraphQL does WebService::GitHub::Role;

method query($query) {
    self.request("/graphql", "POST", data => {
        :$query
    });
}
