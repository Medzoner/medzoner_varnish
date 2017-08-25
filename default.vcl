vcl 4.0;

backend default {
    .host = "172.61.0.6";
    .port = "9061";
}


sub vcl_recv {

    if (req.http.Cookie) {
        set req.http.Cookie = ";" + req.http.Cookie;
        set req.http.Cookie = regsuball(req.http.Cookie, "; +", ";");
        set req.http.Cookie = regsuball(req.http.Cookie, ";(PHPSESSID)=", "; \1=");
        set req.http.Cookie = regsuball(req.http.Cookie, ";[^ ][^;]*", "");
        set req.http.Cookie = regsuball(req.http.Cookie, "^[; ]+|[; ]+$", "");

        if (req.http.Cookie == "") {
            // If there are no more cookies, remove the header to get page cached.
            unset req.http.Cookie;
        }
    }

        if ((req.url ~ "^/cache")) {
            return(pass);
        }
        if ((req.url ~ "^/contact")) {
            return(pass);
        }

        if (req.http.X-Forwarded-Proto == "https" ) {
            set req.http.X-Forwarded-Port = "443";
        } else {
            set req.http.X-Forwarded-Port = "80";
        }

        set req.http.Surrogate-Capability = "abc=ESI/1.0";

        if (req.method == "PURGE") {
                #if (!client.ip ~ purge) {
                #        return(synth(405,"Not allowed."));
                #}
                return (purge);
        }

        if (req.method == "BAN") {
                #if (!client.ip ~ purge) {
                #        return(synth(403, "Not allowed."));
                #}
                ban("req.http.host == " + req.http.host + " && req.url == " + req.url);

                return(synth(200, "Ban added"));
        }
}

sub vcl_backend_response {
    if (beresp.http.Surrogate-Control ~ "ESI/1.0") {
      unset beresp.http.Surrogate-Control;
      set beresp.do_esi = true;
    }
    unset beresp.http.set-cookie;
}
