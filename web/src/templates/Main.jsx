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

    @media (prefers-color-scheme: dark) {
        background-color: #2b2c2f;
    }
`;

const Container = styled.div`
    margin: 48px auto 0 auto;
    flex-grow: 1;

    display: flex;
    flex-direction: row;

    // This (in combination with flex-grow: 1) makes the div take up the remaining
    // space of the screen (from OuterWrapper) that is not taken up by the Nav.
    overflow: auto;

    @media all and (max-width: 600px) {
        margin-right: 20px;
        margin-left: 20px;
    }
`;

const MOBILE_STATE = {
    LIST: "list",
    DETAIL: "detail"
}

class Main extends React.Component {
    state = {
        selectedFilter: null,
        isMobile: false,
        mobileState: MOBILE_STATE.LIST,
        hasSetFromHash: false,
        currentSearchText: ""
    }

    getSelectedFilter() {
        return this.state.selectedFilter || this.props.pageContext.initiallySelectedFilter;
    }

    handleWindowResize() {
        if (window.innerWidth < 600 && !this.state.isMobile) {
            this.setState({ isMobile: true })
        } else if (window.innerWidth >= 600 && this.state.isMobile) {
            this.setState({ isMobile: false })
        }
    }

    handleFilterSelected(filterName, categoryName, fromHash) {
        // TODO: this iterates over 200 filters, make it a map up front :/
        let newFilter = this.props.pageContext.filters.filter((filter) => filter.name === filterName)[0];
        this.setState({
            selectedFilter: newFilter,
            mobileState: (fromHash && !this.state.hasSetFromHash) || !fromHash ? MOBILE_STATE.DETAIL : this.state.mobileState
        });

        if (fromHash) {
            this.setState({ hasSetFromHash: true })
        }
    }

    handleMobileBack() {
        this.setState({
            mobileState: MOBILE_STATE.LIST
        });
    }

    handleSearchBarChange(text) {
        this.setState({
            currentSearchText: text
        });
    }

    renderMobileStateContent() {
        let selectedFilter = this.getSelectedFilter()
        if (this.state.mobileState === MOBILE_STATE.LIST) {
            return (<FilterSelect
                filters={this.props.pageContext.filters}
                onSelectFilter={this.handleFilterSelected.bind(this)}
                onSearchBarChange={this.handleSearchBarChange.bind(this)}
                prepopulatedSearchBarText={this.state.currentSearchText}
                prepopulatedFilterName={selectedFilter && selectedFilter.name}
                className="margin-right--sm" />);
        } else {
            return (
                <FilterDetail filter={this.getSelectedFilter()} displaysBack onClickBack={this.handleMobileBack.bind(this)} />
            );
        }
    }

    renderContent() {
        let selectedFilter = this.getSelectedFilter()
        if (this.state.isMobile) {
            return (<Container>
                {this.renderMobileStateContent()}
            </Container>);
        }
        return (<Container>
            <FilterSelect
                filters={this.props.pageContext.filters}
                onSelectFilter={this.handleFilterSelected.bind(this)}
                onSearchBarChange={this.handleSearchBarChange.bind(this)}
                prepopulatedSearchBarText={this.state.currentSearchText}
                prepopulatedFilterName={selectedFilter && selectedFilter.name}
                className="margin-right--sm" />
            {!this.state.isMobile && <FilterDetail filter={this.getSelectedFilter()} />}
        </Container>);
    }

    render() {
        let selectedFilter = this.getSelectedFilter();
        let title = selectedFilter ?
            `${selectedFilter.name} | Core Image Filter Reference` :
            "Core Image Filter Reference";
        let numFilters = this.props.pageContext.filters.length;
        let description = selectedFilter ? selectedFilter.description :
            `View documentation for ${numFilters} built-in Core Image CIFilter classes on CIFilter.app`
        return (
            <OuterWrapper>
                <Helmet>
                    <title>{title}</title>
                    <meta name="description" content={description} />
                    <meta name="twitter:card" content="summary" />
                    <meta name="twitter:creator" content="@cifilterio" />
                    <meta property="og:title" content={title} />
                    <meta property="og:description" content={description} />
                    { selectedFilter && <meta property="og:url" content={`https://cifilter.app/${selectedFilter.name}/`} />}
                    { selectedFilter && <link rel="canonical" href={`https://cifilter.app/${selectedFilter.name}/`} />}
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

        if (this.props.pageContext.initiallySelectedFilter) {
            this.setState({
                mobileState: MOBILE_STATE.DETAIL
            });
        }
    }
};
export default Main;