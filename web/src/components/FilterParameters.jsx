import React from 'react';
import FilterParameter from './FilterParameter';
import FilterDetailSectionHeading from './FilterDetailSectionHeading';

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
            <FilterDetailSectionHeading>
                {props.parameters.length > 0 ? "Parameters" : "This filter takes no parameters"}
            </FilterDetailSectionHeading>
            <div>{props.parameters.sort((p1, p2) => p1.name.localeCompare(p2.name)).map(
                (parameter) => <FilterParameter
                                    key={parameter.name}
                                    longType={filterHasLongParameterNames(props.parameters)}
                                    parameter={parameter} />
            )}</div>
        </div>
    )
};
export default FilterParameters;