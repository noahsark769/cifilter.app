import React from 'react';
import styled from 'styled-components';

const Name = styled.div`
    font-size: 12px;
    font-weight: bold;
    color: #999;
    margin-bottom: 10px;
`;

const Value = styled.div`
    color: #666;
    font-size: 16px;
    font-family: monospace;
`;

const FilterExampleParameter = (props) => {
    return (
        <>
            <Name>{props.data.name}</Name>
            <Value>{props.data.additionalData}</Value>
        </>
    );
};
export default FilterExampleParameter;