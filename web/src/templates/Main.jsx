import React from 'react';
import styled from 'styled-components';
import Nav from '../components/Nav';
import FilterSelect from '../components/FilterSelect';
import FilterDetail from '../components/FilterDetail';
import { Helmet } from "react-helmet";

const OuterWrapper = styled.div`
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    height: 100vh;
`;

const Container = styled.div`
    margin: 48px auto 0 auto;
    flex-grow: 1;

    display: flex;
    flex-direction: row;
    height: 100%;
`;

class Main extends React.Component {
    state = { selectedFilter: null }

    handleFilterSelected(filterName) {
        // TODO: this iterates over 200 filters, make it a map up front :/
        let newFilter = this.props.pageContext.filters.filter((filter) => filter.name === filterName)[0];
        this.setState({ selectedFilter: newFilter });
    }

    render() {
        console.log(this.props);
        return (
            <OuterWrapper>
                <Helmet>
                    <title>CIFilter Reference</title>
                </Helmet>
                <Nav />
                <Container>
                    <FilterSelect
                        filters={this.props.pageContext.filters}
                        onSelectFilter={this.handleFilterSelected.bind(this)}
                        className="margin-right--sm" />
                    <FilterDetail filter={this.state.selectedFilter} />
                </Container>
            </OuterWrapper>
        );
    }
};
export default Main;