var socketOutput = 0;
var socketEvents = {
    connected: function (data) {
        this.output({ data: 'Web Socket connected' });
        console.log('Web Socket connected');
    },

    close: function (e) {
        this.output({ data: 'Web Socket closed' });
        console.log('Web Socket closed');
    },

    output: function (data) {
        socketOutput++;
        if (document.getElementById('socket-output'))
            document.getElementById('socket-output').innerHTML = `${socketOutput}.  ${data.data}\n` + document.getElementById('socket-output').innerHTML;
    },

    clients: function (data) {
        if (document.getElementById('socket-output')) {
            document.getElementById('client-list').innerHTML = '';

            for (var i = 0; i < data.data.length; i++) {
                var id = data.data[i];
                var template = document.getElementById('btn-template-client').innerHTML;
                document.getElementById('socket-output').innerHTML = `client ${i + 1}: ${id}\n` + document.getElementById('socket-output').innerHTML;
                template = template.replace('{text}', `Client ${i + 1}`);
                template = template.replace('{id}', id);
                document.getElementById('client-list').innerHTML += template;
            }

            initClientList();
        }
    },
}

var socket = new WebSocket("/ws");
socket.onmessage = function (e) {
    var data = JSON.parse(e.data);
    console.log(data);
    if (socketEvents[data.path]) {
        socketEvents[data.path](data);
    }
};

socket.onclose = function (e) {
    socketEvents.close(e);
}


document.getElementById('btn-socket-time')?.addEventListener('click', function () {
    socket.send(JSON.stringify({ path: 'time' }));
});

document.getElementById('btn-socket-fa')?.addEventListener('click', function () {
    socket.send(JSON.stringify({ path: 'fa' }));
});

document.getElementById('btn-socket-clients')?.addEventListener('click', function () {
    socket.send(JSON.stringify({ path: 'clients' }));
});

function initClientList() {
    document.querySelectorAll('.socket-client-send')?.forEach(function (element) {
        element.addEventListener('click', function () {
            var id = this.getAttribute('data-id');
            socket.send(JSON.stringify({ path: 'toclient', data: { id, message: `Hello! how are you?` } }));
        });
    });
}
