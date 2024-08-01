#!/usr/bin/env node
const axios = require('axios');
const url = `https://www.my-stuwe.de//wp-json/mealplans/v1/canteens`;

(async (input) => {
    const {data} = await axios.get(url);
    if (data[input]) {
        let today = data[input].menus.filter(m => m.menuDate === new Date().toISOString().split('T')[0]);
        if (!today.length) {
            console.log('No menu for today');
            return;
        }
        today.forEach(m => {
            console.log(m.menuLine);
            console.log(m.menu.join(', ').replace(/,{1,}/g, ','));
            console.log(m.studentPrice);
            console.log('---');
        });
    } else {
        Object.values(data).forEach(c => {
            console.log(c.canteenId, c.canteen);
        });
    }
})(process.argv[2]);
