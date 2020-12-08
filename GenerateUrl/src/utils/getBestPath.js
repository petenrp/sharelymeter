const getPriceFromDistance = require('./calculate-price-from-distance');
const callGoogleApi = require('./call-google-api');

module.exports = (API_KEY) => {
    return async (req) => {
        const [user1, user2] = req;
            
        const path_1 = [user1.src, user2.src, user1.dest, user2.dest];
        const response_1 = await callGoogleApi(path_1, API_KEY);
        const distance_1 = response_1.routes[0].legs.reduce((acc, current) => acc + current.distance.value, 0)

        const path_2 = [user1.src, user2.src, user2.dest, user1.dest];
        const response_2 = await callGoogleApi(path_2, API_KEY);
        const distance_2 = response_2.routes[0].legs.reduce((acc, current) => acc + current.distance.value, 0)

        const path_3 = [user2.src, user1.src, user1.dest, user2.dest];
        const response_3 = await callGoogleApi(path_3, API_KEY);
        const distance_3 = response_3.routes[0].legs.reduce((acc, current) => acc + current.distance.value, 0)

        const path_4 = [user2.src, user1.src, user2.dest, user1.dest];
        const response_4 = await callGoogleApi(path_4, API_KEY);
        const distance_4 = response_4.routes[0].legs.reduce((acc, current) => acc + current.distance.value, 0)

        const allPossibility = [
            {
                left: true,
                distance: distance_1,
                path: path_1,
                estimatedPrice: getPriceFromDistance(distance_1 / 1000),
            },
            {
                left: true,
                distance: distance_2,
                path: path_2,
                estimatedPrice: getPriceFromDistance(distance_2 / 1000),
            },
            {
                left: false,
                distance: distance_3,
                path: path_3,
                estimatedPrice: getPriceFromDistance(distance_3 / 1000),
            },
            {
                left: false,
                distance: distance_4,
                path: path_4,
                estimatedPrice: getPriceFromDistance(distance_4 / 1000),
            },
        ].sort((a, b) => {
            return a.distance - b.distance;
        });

        return allPossibility.length > 0 ? allPossibility[0]: null;
    };
};