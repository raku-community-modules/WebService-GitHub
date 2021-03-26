use v6;

use WebService::GitHub::Role;

class WebService::GitHub::Search does WebService::GitHub::Role {
    method repositories(%data) {
        self.request('/search/repositories', :%data)
    }

    method code(%data) {
        self.request('/search/code', :%data)
    }

    method issues(%data) {
        self.request('/search/issues', :%data)
    }

    method users(%data) {
        self.request('/search/users', :%data)
    }
}