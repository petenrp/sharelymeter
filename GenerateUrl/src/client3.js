const io = require('socket.io-client');

// const socket = io('https://afternoon-tor-56476.herokuapp.com');
const socket = io('http://localhost:3000');

console.log(socket.connected); // false

socket.on('connect', (e) => {
    console.log('Connected'); // true
  
    socket.emit('user', JSON.stringify({
        id: 3,
        name: "Aof",
        tel: '08000000002'
    }));

  socket.emit('request', {
      src: {
          lat: 13.655127, 
          lng: 100.498858,
      },
      dest: {
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

socket.on('result', (result) => {
    console.log(`Result ${result}`);
});

socket.on('disconnect', () => {
  console.log(socket.connected); // false
});

socket.on('error', (e) => {
    console.log(e)
})

// socket.connect();
