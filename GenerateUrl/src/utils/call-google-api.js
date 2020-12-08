const axios = require('axios');

const latlngToString = ({lat, lng}) => {
    return `${lat},${lng}`;
};

module.exports = async (path, API_KEY) => {
    const [p1, p2, p3, p4] = path;

    const origin = latlngToString(p1);
    const destination = latlngToString(p4);
    const waypoints = `${latlngToString(p2)}|${latlngToString(p3)}`;
    
    const response = await axios.get(`https://maps.googleapis.com/maps/api/directions/json?origin=${origin}&destination=${destination}&waypoints=${waypoints}&key=${API_KEY}`)
    return response.data;
};