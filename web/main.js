if (!self.fetch) {
    alert("Обнови браузер, наркоман!");
    throw "I am a faggot";
}

fetch("http://alpha.rogalik.tatrix.org/petroll")
    .then(function(response) {
        return response.json();
    }).
    then(function(json) {
        renderPlayer(json.empire, "empire", json.thread);
        renderPlayer(json.confederation, "confederation", json.thread);
    });


function renderPlayer(player, id, thread) {
    var current = document.querySelector("#" + id + " .hp-current");
    current.style.width = player.hp + "%";
    current.textContent = player.hp + " / " + 100;

    var posts = document.querySelector("#" + id + " .posts");
    posts.innerHTML = "";
    player.posts.forEach(function(post) {
        var link = document.createElement("a");
        link.className = "post";
        link.target = "_blank";
        link.href = "https://2ch.hk/b/res/" + thread + ".html#" + post;
        link.textContent = post;
        posts.appendChild(link);
    });
}
