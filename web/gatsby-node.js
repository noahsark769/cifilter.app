const fs = require('fs');
const path = require('path');

// https://stackoverflow.com/questions/18112204/get-all-directories-within-directory-nodejs
const isDirectorySync = (source) => fs.lstatSync(source).isDirectory()
const getDirectoriesSync = (source) => {
  return fs.readdirSync(source).map(name => path.join(source, name)).filter(isDirectorySync)
}

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

const combineFilterDataWithExampleData = (data) => {
    return Promise.all(data.map((filter) => {
        const name = filter.name;
        const examplesDirectoryPath = path.resolve(`src/data/examples/${name}/`);
        if (!fs.existsSync(examplesDirectoryPath)) {
            return Promise.resolve({
                ...filter,
                examples: null
            });
        }

        const exampleDirectoryPaths = getDirectoriesSync(examplesDirectoryPath);
        return Promise.all(exampleDirectoryPaths.map((exampleDirectoryPath) => {
            return readJsonAsync(path.join(exampleDirectoryPath, "metadata.json")).then((json) => {
                const id = path.basename(exampleDirectoryPath)
                return {
                    id: id,
                    data: json,
                    basepath: `examples/${name}/${id}`
                };
            })
        })).then((examples) => {
            return {
                ...filter,
                examples: examples
            }
        });
    }));
};

exports.createPages = ({ graphql, actions }) => {
    const { createPage } = actions;

    return new Promise((resolve, reject) => {
        const templateComponent = path.resolve(`src/templates/Main.jsx`);

        readJsonAsync(path.resolve(`src/data/filters.json`)).then((data) => {
            combineFilterDataWithExampleData(data).then((filters) => {
                createPage({
                    path: '/',
                    component: templateComponent,
                    context: {
                        filters: filters
                    }
                });
                filters.forEach((filter) => {
                    createPage({
                        path: `/${filter.name}/`,
                        component: templateComponent,
                        context: {
                            filters: filters,
                            initiallySelectedFilter: filter
                        },
                    })
                    console.log(`Created page for ${filter.name}`);
                });
            });
            resolve();
        });
    })
}
