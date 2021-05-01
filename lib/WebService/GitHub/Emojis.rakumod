use WebService::GitHub::Role;

class WebService::GitHub::Emojis does WebService::GitHub::Role {

    method list() {
        self.request("/emojis","GET");
    }

}
