const io = require('socket.io-client');

const socket = io('https://afternoon-tor-56476.herokuapp.com', {
    transport: ['websocket'],
    autoConnect: false,
});
// const socket = io('http://localhost:3000');

console.log(socket.connected); // false

socket.on('connect', (e) => {
    console.log('Connected'); // true
  
    socket.emit('user', JSON.stringify({
        id: 2,
        name: "Game",
        tel: '0800420423'
    }));

  socket.emit('request', {
      src: {
        name: "The Cube",
        lat: 13.655127, 
        lng: 100.498858,
      },
      dest: {
        name: "Green day night market",
        lat: 13.662462, 
        lng: 100.438272,
      }
  });
    // socket.emit('request', {
    //     src: {
    //         lat: 13.6494925, 
    //         lng: 100.4953804,
    //     },
    //     dest: {
    //         lat: 13.664666, 
    //         lng: 100.441415,
    //     }
    // });
});

socket.on('reconnecting', (n) => {
    console.error(`Reconnecting: ${n} th`);
})

socket.on('cancel', (v) => {
    console.log('SERVER CANCEL THE MATCH');
});

socket.on('result', (result) => {
    // console.log(`Result ${result}`);
    console.log('Result');
    console.log(JSON.parse(result))
    setTimeout(() => {
        socket.emit('confirm', '');
    }, 1000);
});

socket.on('disconnect', () => {
  console.log(socket.connected); // false
});

socket.on('status', (message) => {
    console.log(`Status:`)
    console.log(message);

    if(message.status == 'one_user_on_taxi') {
        socket.emit('getInOut', JSON.stringify({
            taxi: 50
        }));
    }
});

socket.on('re_enter_taxi', (message) => {
    console.log(message);
    socket.emit('getInOut', JSON.stringify({
        taxi: 50
    }));
});

socket.on('confirm_metre', (message) => {
    console.log(message);
    socket.emit('taxi', JSON.stringify({
        confirm: true,
    }));
});

socket.on('done', (message) => {
    console.log(message);
});

socket.on('error', (e) => {
    console.log(e)
})

socket.connect();