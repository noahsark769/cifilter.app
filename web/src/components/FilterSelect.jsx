import React from 'react';
import styled, { css } from 'styled-components';
import SearchBar from './SearchBar';

const SELECT_CATEGORY_NAMES = [
    "CICategoryBlur",
    "CICategoryColorAdjustment",
    "CICategoryColorEffect",
    "CICategoryCompositeOperation",
    "CICategoryDistortionEffect",
    "CICategoryGenerator",
    "CICategoryGeometryAdjustment",
    "CICategoryGradient",
    "CICategoryHalftoneEffect",
    "CICategoryReduction",
    "CICategorySharpen",
    "CICategoryStylize",
    "CICategoryTileEffect",
    "CICategoryTransition",
];

function intersection(setA, setB) {
    var _intersection = new Set();
    for (var elem of setB) {
        if (setA.has(elem)) {
            _intersection.add(elem);
        }
    }
    return _intersection;
}

const groupFilters = (filters, categories, isIncluded) => {
    let map = new Map();
    let categoriesSet = new Set(categories.concat(["Other"]));
    for (let category of categoriesSet) {
        map.set(category, []);
    }

    for (let filter of filters) {
        if (!isIncluded(filter.name)) {
            continue
        }

        let categoryIntersection = intersection(categoriesSet, new Set(filter.categories));
        if (categoryIntersection.size > 0) {
            // wonky first-item-of-set syntax...
            let category = categoryIntersection.values().next().value;
            let applicableFilters = map.get(category);
            applicableFilters.push(filter.name);
            map.set(category, applicableFilters)
        } else {
            let uncategorized = map.get("Other");
            uncategorized.push(filter.name);
            map.set("Other", uncategorized)
        }
    }

    for (let category of categoriesSet) {
        if (map.get(category).length == 0) {
            map.delete(category);
        }
    }

    return map;
};

const mapMap = (map, transform) => {
    let result = [];
    map.forEach((value, key, map) => {
        result.push(transform(value, key, map));
    })
    return result
};

const Container = styled.div`
    width: 350px;
    height: 100%;
    overflow-y: scroll;
    padding-bottom: 48px;
`;

const FilterName = styled.div`
    font-size: 14px;
    color: #a4a4a4;
    padding: 5px 0 5px 8px;
    border-left: 2px solid #dddddd;
    cursor: pointer;

    ${(props) => props.highlighted && css`
        color: #F5BD5D;
        border-left: 2px solid #F5BD5D;
    `};

    &:hover {
        border-left: 2px solid #a4a4a4;
        color: #666666;

        ${(props) => props.highlighted && css`
            color: #F5BD5D;
            border-left: 2px solid #F5BD5D;
        `};
    }
`;

const Category = styled.div`
    font-weight: bold;
    font-size: 18px;
`;

const EntryContainer = styled.div`
    margin: 24px;
    &:first-child {
        margin-top: 0;
    }
`;

const SearchBarWrapper = styled.div`
    margin: 0 24px;
    width: 80%;
`;

class FilterSelect extends React.Component {
    state = {
        groupedFilters: groupFilters(
            this.props.filters,
            SELECT_CATEGORY_NAMES,
            (filterName) => true
        ),
        selectedFilterName: null
    };

    handleSearchBarChange(newText) {
        this.setState({
            groupedFilters: groupFilters(
                this.props.filters,
                SELECT_CATEGORY_NAMES,
                (filterName) => filterName.toLowerCase().includes(newText.toLowerCase())
            )
        })
    }

    handleFilterClick(filterName) {
        this.props.onSelectFilter(filterName);
        this.setState({
            selectedFilterName: filterName
        });
    };

    renderFilterNames(filterNames) {
        let _this = this;
        return (
            <ul>
                {filterNames.map(function(filterName) {
                    return <FilterName
                        key={filterName}
                        onClick={_this.handleFilterClick.bind(_this, filterName)}
                        highlighted={_this.state.selectedFilterName == filterName}
                    >{filterName}</FilterName>
                })}
            </ul>
        );
    }

    renderEntry(categoryName, filterNames) {
        return (
            <EntryContainer key={categoryName}>
                <Category className="margin-bottom--sm">{categoryName}</Category>
                {this.renderFilterNames(filterNames)}
            </EntryContainer>
        );
    }

    render() {
        let _this = this;
        return (
            <Container className={this.props.className}>
                <SearchBarWrapper>
                    <SearchBar onChange={this.handleSearchBarChange.bind(this)} />
                </SearchBarWrapper>  
                {mapMap(this.state.groupedFilters, function(value, key, map) {
                    return _this.renderEntry(key, value);
                })}
            </Container>
        );
    }
}
export default FilterSelect;