import React from 'react';
import styled, { css } from 'styled-components';

export const MatchType = Object.freeze({
    NONE: Symbol("NONE"),
    NAME: Symbol("NAME"),
    DESCRIPTION: Symbol("DESCRIPTION"),
    PARAMETER_NAME: Symbol("PARAMETER_NAME"),
    PARAMETER_VALUE: Symbol("PARAMETER_VALUE")
});

function colorFromMatchType(matchType) {
    switch (matchType) {
        case MatchType.NONE:
            return "rgba(0, 0, 0, 0)";
        case MatchType.NAME:
            return "rgba(0, 0, 0, 0)";
        case MatchType.DESCRIPTION:
            return "#74AEDF";
        case MatchType.PARAMETER_NAME:
            return "#FF8D8D";
        case MatchType.PARAMETER_VALUE:
            return "#FF8D8D";
        default:
            return "red";
    }
}

function textFromMatchType(matchType) {
    switch (matchType) {
        case MatchType.NONE:
            return "";
        case MatchType.NAME:
            return "";
        case MatchType.DESCRIPTION:
            return "desc";
        case MatchType.PARAMETER_NAME:
            return "param";
        case MatchType.PARAMETER_VALUE:
            return "param";
        default:
            return "";
    }
}

const Container = styled.div`
    display: flex;
    flex-direction: row;
`;

const FilterName = styled.div`
    font-size: 14px;
    color: #a4a4a4;
    padding: 5px 0 5px 8px;
    border-left: 2px solid #dddddd;
    cursor: pointer;
    flex-grow: 1;

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

const ResultIndicator = styled.div`
    font-size: 11px;
    background-color: red;
    color: white;
    padding: 3px 5px;
    border-radius: 3px;
    margin: 2px 0;

    background-color: ${(props) => colorFromMatchType(props.matchType)}
`;

const FilterSelectResult = (props) => {
    return (
        <Container onClick={props.onClick}>
            <FilterName highlighted={props.highlighted}>{props.result.filter.name}</FilterName>
            <ResultIndicator matchType={props.result.matchType}>{textFromMatchType(props.result.matchType)}</ResultIndicator>
        </Container>
    );
};
export default FilterSelectResult;