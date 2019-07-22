module.exports = {
  siteMetadata: {
    title: `CIFilter.io: Core Image Filter Reference`,
    siteUrl: `https://cifilter.io`
  },
  plugins: [
    'gatsby-plugin-react-helmet',
    {
      resolve: `gatsby-source-filesystem`,
      options: {
        name: `images`,
        path: `${__dirname}/src/images`,
      },
    },
    'gatsby-transformer-sharp',
    'gatsby-plugin-sharp',
    {
      resolve: `gatsby-source-filesystem`,
      options: {
        name: `data`,
        path: `${__dirname}/src/data`,
      },
    },
    `gatsby-plugin-sass`,
    `gatsby-plugin-favicon`,
    `gatsby-plugin-force-trailing-slashes`,
    `gatsby-plugin-styled-components`,
    `gatsby-plugin-sitemap`
  ],
}
