import React from 'react';
import styled from 'styled-components';
import Nav from '../components/Nav';
import FilterSelect from '../components/FilterSelect';
import FilterDetail from '../components/FilterDetail';
import { Helmet } from "react-helmet";
import ReactGA from 'react-ga';

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

const MOBILE_STATE = {
    LIST: "list",
    DETAIL: "detail"
}

class Main extends React.Component {
    state = {
        selectedFilter: null,
        isMobile: false,
        mobileState: MOBILE_STATE.LIST
    }

    handleWindowResize() {
        console.log(`Window resize: ${window.innerWidth}`);
        if (window.innerWidth < 600 && !this.state.isMobile) {
            this.setState({ isMobile: true })
        } else if (window.innerWidth >= 600 && this.state.isMobile) {
            this.setState({ isMobile: false })
        }
    }

    handleFilterSelected(filterName) {
        // TODO: this iterates over 200 filters, make it a map up front :/
        let newFilter = this.props.pageContext.filters.filter((filter) => filter.name === filterName)[0];
        this.setState({
            selectedFilter: newFilter,
            mobileState: MOBILE_STATE.DETAIL
        });
    }

    renderMobileStateContent() {
        console.log(this.state.mobileState);
        if (this.state.mobileState === MOBILE_STATE.LIST) {
            return (<FilterSelect
                filters={this.props.pageContext.filters}
                onSelectFilter={this.handleFilterSelected.bind(this)}
                className="margin-right--sm" />);
        } else {
            return (<FilterDetail filter={this.state.selectedFilter} />);
        }
    }

    renderContent() {
        if (this.state.isMobile) {
            return (<Container>
                {this.renderMobileStateContent()}
            </Container>);
        }
        return (<Container>
            <FilterSelect
                filters={this.props.pageContext.filters}
                onSelectFilter={this.handleFilterSelected.bind(this)}
                className="margin-right--sm" />
            {!this.state.isMobile && <FilterDetail filter={this.state.selectedFilter} />}
        </Container>);
    }

    render() {
        return (
            <OuterWrapper>
                <Helmet>
                    <title>CIFilter Reference</title>
                </Helmet>
                <Nav />
                {this.renderContent()}
            </OuterWrapper>
        );
    }

    componentDidMount() {
        ReactGA.initialize('UA-136382558-1');
        ReactGA.pageview(window.location.pathname + window.location.search);

        window.addEventListener('resize', this.handleWindowResize.bind(this))
        this.handleWindowResize();
    }
};
export default Main;