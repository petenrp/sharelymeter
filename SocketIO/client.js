const io = require('socket.io-client');

const socket = io('https://afternoon-tor-56476.herokuapp.com');
// const socket = io('http://localhost:3000');

console.log(socket.connected); // false

socket.on('connect', () => {
  console.log(socket.connected); // true
  socket.emit('userID', 1);
  socket.emit('request', {
      src: {
          lat: 13.6512206,
          lng: 100.4941857
      },
      dest: {
          lat: 13.662613,
          lng: 100.437351
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