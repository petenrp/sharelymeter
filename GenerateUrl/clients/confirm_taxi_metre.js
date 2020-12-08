const axios = require('axios');
const url = require('url');
const open = require('open');

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

(async () => {
    const response = await axios.get('https://afternoon-tor-56476.herokuapp.com/all')
    const aliveSocket = response.data.filter( s => s.alive )
    if(aliveSocket.length > 0) {

        const socket = aliveSocket[0].socket;
        const result = url.format({
            protocol: 'https',
            hostname: 'afternoon-tor-56476.herokuapp.com',
            pathname: '/publish',
            query: {
                socketId: socket,
                topic: 'confirm_metre',
                body: JSON.stringify({
                    taxi: 120
                }),
            },
        });

        await axios.get(result);
    }
})();