import React from 'react';
import styled from 'styled-components';
import FilterParameter from './FilterParameter';

const Heading = styled.div`
    font-size: 14px;
    font-weight: bold;
    color: #F5BD5D;
    text-transform: uppercase;
`;

function filterHasLongParameterNames(parameters) {
    for (let parameter of parameters) {
        if (parameter.classType.length > 15) {
            return true;
        }
    }
    return false;
}

const FilterParameters = (props) => {
    return (
        <div>
            <Heading className="margin-bottom--md margin-top--lg">Parameters</Heading>
            <div>{props.parameters.sort((p1, p2) => p1.name.localeCompare(p2.name)).map(
                (parameter) => <FilterParameter
                                    longType={filterHasLongParameterNames(props.parameters)}
                                    parameter={parameter} />
            )}</div>
        </div>
    )
};
export default FilterParameters;