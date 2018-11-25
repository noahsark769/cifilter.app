const fs = require('fs');
const path = require('path');

const readJsonAsync = (filepath, callback) => {
    return new Promise((resolve, reject) => {
        fs.readFile(filepath, 'utf-8', function(err, data) {
            if (err) {
                reject(err);
            } else {
                const result = JSON.parse(data);
                if (result) {
                    resolve(result);
                } else {
                    throw new Error("Json parse error");
                }
            }
        });
    });
}

exports.createPages = ({ graphql, actions }) => {
    const { createPage } = actions

    return new Promise((resolve, reject) => {
        const templateComponent = path.resolve(`src/templates/Main.jsx`)

        readJsonAsync(path.resolve(`src/data/filters.json`)).then((data) => {
            createPage({
                path: '/',
                component: templateComponent,
                context: data
            });
            // data.pages.forEach((pageData) => {
            //     const pagePath = pageData.pagePath;
            //     createPage({
            //         path: pagePath,
            //         component: templateComponent,
            //         context: pageData,
            //     })
            // });
            resolve();
        });
    })
}
