const priceTable = [
    { threshold: 1, cost: 35 },
    { threshold: 10, cost: 5.5 },
    { threshold: 20, cost: 6.5 },
    { threshold: 40, cost: 7.5 },
    { threshold: 60, cost: 8 },
    { threshold: 80, cost: 9 },
    { threshold: Infinity, cost: 10.50 }
];

module.exports = (distance) => {
    distance = Math.ceil(parseFloat(distance));
    let price = 0;
    let accumulateDistance = 0;
    let index = 0;
    while(index < priceTable.length && accumulateDistance < distance ) {
        const current = priceTable[index];
        if ( distance > current.threshold ) {
            price += (current.threshold - accumulateDistance) * current.cost;
        } else {
            price += (distance - accumulateDistance) * current.cost;
        }
        index++;
        accumulateDistance = current.threshold;
    }
    return Math.ceil(price);
};