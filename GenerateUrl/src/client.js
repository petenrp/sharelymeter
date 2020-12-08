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
        id: 1,
        name: "Ying",
        tel: '0984787891'
    }));

  socket.emit('request', {
      src: {
        name: "KMUTT",
        lat: 13.655127, 
        lng: 100.498858,
      },
      dest: {
        name: "Central Rama 2",
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
    // socket.emit('confirm', '');
    
    socket.emit('confirm', '');
});

socket.on('disconnect', () => {
  console.log(socket.connected); // false
});

socket.on('status', (message) => {
    console.log(`Status:`)
    console.log(message);

    if(message.status == 'no_one_on_taxi') {
        socket.emit('getInOut', JSON.stringify({

        }));
    }

    if(message.status == 'two_user_on_taxi') {
        socket.emit('getInOut', JSON.stringify({
            taxi: 100,
        }));
    }
});

socket.on('re_enter_taxi', (message) => {
    console.log(message);
});

let i = 0;

socket.on('confirm_metre', (message) => {
    console.log(message);
    i++;
    socket.emit('taxi', JSON.stringify({
        confirm: i >= 4,
    }));
});

socket.on('done', (message) => {
    console.log(message);
});

socket.on('error', (e) => {
    console.log(e)
})

socket.connect();