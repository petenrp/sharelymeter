const io = require('socket.io-client');

// const socket = io('https://afternoon-tor-56476.herokuapp.com');
const socket = io('http://localhost:3000');

console.log(socket.connected); // false

socket.on('connect', () => {
  console.log(socket.connected); // true
  socket.emit('userID', 2);
  socket.emit('request', {
      src: {
          lat: 13.649924,
          lng: 100.488504
      },
      dest: {
          lat: 13.664861,
          lng: 100.441610
      }
  });
});

socket.on('reconnecting', (n) => {
    console.error(`Reconnecting: ${n} th`);
})

socket.on('result', (result) => {
    console.log(`We can go with userID: ${result}`);
});

socket.on('disconnect', () => {
  console.log(socket.connected); // false
});