import React from 'react';
import styled, { css } from 'styled-components';

const Container = styled.div`
    display: flex;
    flex-direction: ${ props => props.horizontal ? "row" : "column" }
`;

const Name = styled.div`
    font-size: 12px;
    font-weight: bold;
    color: #999;
    margin-bottom: 10px;
    ${props => props.horizontal && css`
        flex: 3
    `}
`;

const Value = styled.div`
    color: #666;
    font-size: 16px;
    font-family: monospace;
    ${props => props.horizontal && css`
        flex: 1;
        text-align: right;
    `}
`;

function displayValueFromPropsData(data) {
    switch (data.type) {
        case "number": return data.additionalData.value;
        case "color": return data.additionalData;
        case "vector": return data.additionalData.value.join(", ");
        default:
            console.error(`Unrecognized filter parameter type ${data.type}`);
    }
}

function shouldDisplayHorizontally(data) {
    return false;
    switch (data.type) {
        case "number": return true;
        default:
            return false;
    }
}

const FilterExampleParameter = (props) => {
    const displayValue = displayValueFromPropsData(props.data);
    const isHorizontal = shouldDisplayHorizontally(props.data);
    return (
        <Container horizontal={isHorizontal} className={props.className}>
            <Name horizontal={isHorizontal}>{props.data.name}</Name>
            <Value horizontal={isHorizontal}>{displayValue}</Value>
        </Container>
    );
};
export default FilterExampleParameter;