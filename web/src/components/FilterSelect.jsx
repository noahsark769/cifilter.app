import React from 'react';
import styled, { css } from 'styled-components';
import SearchBar from './SearchBar';
import FilterSelectResult, { MatchType } from './FilterSelectResult';

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

/**
 * Returns a MAP of the following structure:
 *
 * {
 *   "category_name": [
 *     {
 *       "match_type": MatchType.NAME,
 *       "filter": { ... }
 *     }
 *   ]
 * }
 *
 * The isMatch function takes in a filter and should return a MatchType. MatchType.NONE
 * will be filtered out.
 */
const groupFilters = (filters, categories, isMatch) => {
    let map = new Map();
    let categoriesSet = new Set(categories.concat(["Other"]));
    for (let category of categoriesSet) {
        map.set(category, []);
    }

    for (let filter of filters) {
        let matchType = isMatch(filter);
        if (matchType === MatchType.NONE) {
            continue
        }

        let categoryIntersection = intersection(categoriesSet, new Set(filter.categories));
        if (categoryIntersection.size > 0) {
            // wonky first-item-of-set syntax...
            let category = categoryIntersection.values().next().value;
            let applicableFilters = map.get(category);
            applicableFilters.push({
                matchType: matchType,
                filter: filter
            });
            map.set(category, applicableFilters)
        } else {
            let uncategorized = map.get("Other");
            uncategorized.push({
                matchType: matchType,
                filter: filter
            });
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
            (filter) => MatchType.NAME
        ),
        selectedFilterName: null,
        selectedFilterParentCategoryName: null
    };

    handleSearchBarChange(newText) {
        this.setState({
            groupedFilters: groupFilters(
                this.props.filters,
                SELECT_CATEGORY_NAMES,
                (filter) => {
                    if (filter.name.toLowerCase().includes(newText.toLowerCase())) {
                        return MatchType.NAME;
                    }
                    for (let parameter of filter.parameters) {
                        if (parameter.name.toLowerCase().includes(newText.toLowerCase())) {
                            return MatchType.PARAMETER_NAME;
                        }
                        if (parameter.description) {
                            if (parameter.description.toLowerCase().includes(newText.toLowerCase())) {
                                return MatchType.PARAMETER_VALUE;
                            }
                        }
                    }
                    if (filter.description.toLowerCase().includes(newText.toLowerCase())) {
                        return MatchType.DESCRIPTION;
                    }
                    return MatchType.NONE;
                }
            )
        })

        if (this.props.onSearchBarChange) {
            this.props.onSearchBarChange(newText);
        }
    }

    handleFilterClick(filter, categoryName, fromHash) {
        this.props.onSelectFilter(filter.name, categoryName, fromHash);
        this.setState({
            selectedFilterName: filter.name,
            selectedFilterParentCategoryName: categoryName
        });
        window.history.pushState(
            {
                selectedFilterName: filter.name,
                selectedFilterParentCategoryName: categoryName
            },
            filter.name,
            `/${filter.name}/`
        );
    };

    // Select either the next (forward == true) or previous (forward == false)
    // filter in the tree. This is basically an interview question.
    advanceFilterSelection(forward) {
        if (!this.state.selectedFilterName || !this.state.selectedFilterParentCategoryName) {
            return;
        }

        const categoryName = this.state.selectedFilterParentCategoryName;
        const filterName = this.state.selectedFilterName;

        const categories = Array.from(this.state.groupedFilters.keys());
        const indexOfCurrentCategory = categories.indexOf(categoryName);

        const currentFilterResults = this.state.groupedFilters.get(categoryName);
        const currentFilterNames = currentFilterResults.map(result => result.filter.name);
        const indexOfCurrentFilter = currentFilterNames.indexOf(filterName);

        if (indexOfCurrentFilter === currentFilterNames.length - 1 && forward) {
            // we need to step into the next category
            if (indexOfCurrentCategory === categories.length - 1) {
                // we're at the end of the categories, nothing to do
                return;
            } else {
                // step to the 0th element of the next category
                const newCategory = categories[indexOfCurrentCategory + 1];
                this.handleFilterClick(this.state.groupedFilters.get(newCategory)[0].filter, newCategory, false);
            }
        } else if (indexOfCurrentFilter === 0 && !forward) {
            // we need to step into the last category
            if (indexOfCurrentCategory === 0) {
                // we're at the beginning of the categories, nothing to do
                return;
            } else {
                // step to the last element of the previous category
                const newCategory = categories[indexOfCurrentCategory - 1];
                const newFilters = this.state.groupedFilters.get(newCategory).map(result => result.filter);
                this.handleFilterClick(newFilters[newFilters.length - 1], newCategory, false);
            }
        } else {
            // we just need to step
            const newFilter = currentFilterResults[indexOfCurrentFilter + (forward ? 1 : -1)].filter;
            this.handleFilterClick(newFilter, categoryName, false);
        }

    }

    handleKeyPress(keyCode) {
        // arrow up/down button should select next/previous list element
        if (keyCode === 38) { // up
            this.advanceFilterSelection(false);
        } else if (keyCode === 40) { // down
            this.advanceFilterSelection(true);
        }
    }

    renderFilterResults(filterResults, categoryName) {
        let _this = this;
        return (
            <ul>
                {filterResults.map(function(filterResult) {
                    return <FilterSelectResult
                        key={filterResult.filter.name}
                        result={filterResult}
                        onClick={_this.handleFilterClick.bind(_this, filterResult.filter, categoryName, false)}
                        highlighted={_this.state.selectedFilterName == filterResult.filter.name}
                    >{filterResult.filter.name}</FilterSelectResult>
                })}
            </ul>
        );
    }

    renderEntry(categoryName, filterResults) {
        return (
            <EntryContainer key={categoryName}>
                <Category className="margin-bottom--sm">{categoryName}</Category>
                {this.renderFilterResults(filterResults, categoryName)}
            </EntryContainer>
        );
    }

    componentDidMount() {
        let _this = this;
        document.body.addEventListener('keydown', function(event) {
            var key = event.keyCode || event.charCode || 0;
            _this.handleKeyPress(key);
        });

        const hash = window.location.hash.replace("#", "");
        if (hash) {
            for (let [categoryName, filterResults] of this.state.groupedFilters[Symbol.iterator]()) {
                for (let filterResult of filterResults) {
                    if (filterResult.filter.name === hash) {
                        this.handleFilterClick(filterResult.filter, categoryName, true);
                    }
                }
            }
        } else if (this.props.prepopulatedFilterName) {
            for (let [categoryName, filterResults] of this.state.groupedFilters[Symbol.iterator]()) {
                for (let filterResult of filterResults) {
                    if (filterResult.filter.name === this.props.prepopulatedFilterName) {
                        this.setState({
                            selectedFilterName: filterResult.filter.name,
                            selectedFilterParentCategoryName: categoryName
                        });
                    }
                }
            }
        }

        if (this.props.prepopulatedSearchBarText) {
            this.handleSearchBarChange(this.props.prepopulatedSearchBarText);
        }
    }

    render() {
        let _this = this;
        return (
            <Container className={this.props.className}>
                <SearchBarWrapper>
                    <SearchBar onChange={this.handleSearchBarChange.bind(this)} initialText={this.props.prepopulatedSearchBarText} />
                </SearchBarWrapper>  
                {mapMap(this.state.groupedFilters, function(value, key, map) {
                    return _this.renderEntry(key, value);
                })}
            </Container>
        );
    }
}
export default FilterSelect;