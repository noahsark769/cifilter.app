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
        case "string": return data.additionalData.value;
        default:
            console.error(`Unrecognized filter parameter type ${data.type}`);
    }
}

const FilterExampleParameter = (props) => {
    const displayValue = displayValueFromPropsData(props.data);
    return (
        <Container horizontal={false} className={props.className}>
            <Name horizontal={false}>{props.data.name}</Name>
            <Value horizontal={false}>{displayValue}</Value>
        </Container>
    );
};
export default FilterExampleParameter;