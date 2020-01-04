import React from 'react';
import styled from 'styled-components';
import FilterExampleImage from './FilterExampleImage';
import FilterExampleParameter from './FilterExampleParameter';
import FilterDetailSectionHeading from './FilterDetailSectionHeading';
import HorizontalImageConfiguration from './HorizontalImageConfiguration';
import { IoIosArrowRoundDown } from 'react-icons/io';
import chunk from 'lodash.chunk';

// Note: We have WasCropped, but we don't use it here yet (#42)

const FlexParent = styled.div`
    display: flex;
    flex-direction: ${props => props.column ? "column" : "row"};
`;

const Container = styled.div`
    display: flex;
    flex-direction: row;
`;

const Column = styled.div`
    flex: 1;
    display: flex;
    flex-direction: column;
    &:first-child {
        margin-right: 24px;
    }
`;

const ArrowContainer = styled.div`
    flex: 1;
    display: flex;
    flex-direction: row;
    justify-content: center;
    margin: 20px 0;
    width: 100%;
`;

const OutputImageContainer = styled.div`
    display: flex;
    flex-direction: row;
    justify-content: center;
`;

const OutputImageWrapper = styled.div`
    flex-grow: 0.46;
`;

const NormalImageConfiguration = (props) => {
    let nonImageParameterArrays;
    if (props.imageParameters.length > 0) {
        nonImageParameterArrays = [props.nonImageParameters];
    } else {
        nonImageParameterArrays = chunk(props.nonImageParameters, 2);
    }
    return (
        <FlexParent column>
            <Container>
                { props.imageParameters.length > 0 &&
                    <Column>
                        {props.imageParameters.map((value) => {
                            const {name, additionalData} = value;
                            return (<FilterExampleImage
                                        key={name}
                                        name={name}
                                        filename={`${props.basepath}/${additionalData.image}`}
                                        filterName={props.filterName}
                                        className="margin-bottom--md"
                                    />);
                        })}
                    </Column>
                }
                {nonImageParameterArrays.map((nonImageParameters, index) => {
                    return <Column key={index}>
                        {nonImageParameters.map((value) => {
                            return (<FilterExampleParameter
                                        key={value.name}
                                        data={value}
                                        className="margin-bottom--md"
                                    />);
                        })}
                    </Column>
                })}
            </Container>
            <ArrowContainer>
                <IoIosArrowRoundDown size={50} color="#999" />
            </ArrowContainer>
            <OutputImageContainer>
                <OutputImageWrapper>
                    <FilterExampleImage
                        name="outputImage"
                        filename={`${props.basepath}/${props.outputImageData.image}`}
                        filterName={props.filterName}
                    />
                </OutputImageWrapper>
            </OutputImageContainer>
        </FlexParent>
    );
};

const FilterExample = (props) => {
    const outputImageData = props.example.data.parameterValues.filter(
        ({ name }) => name === 'outputImage'
    )[0];

    const nonImageParameters = props.example.data.parameterValues.filter(({ type }) => type !== "image");
    const imageParameters = props.example.data.parameterValues.filter(
        ({ type, name }) => type === "image" && name !== "outputImage"
    );

    let rendered;
    if (nonImageParameters.length === 0 && imageParameters.length <= 2) {
        rendered = (<HorizontalImageConfiguration
            basepath={props.example.basepath}
            outputImageData={outputImageData.additionalData}
            parameterValues={props.example.data.parameterValues}
            filterName={props.filterName}
            />);
    } else {
        rendered = (<NormalImageConfiguration
            basepath={props.example.basepath}
            outputImageData={outputImageData.additionalData}
            nonImageParameters={nonImageParameters}
            imageParameters={imageParameters}
            filterName={props.filterName}
            />); 
    }

    return (
        <>
            <FilterDetailSectionHeading>Examples for <strong>{props.filterName}</strong></FilterDetailSectionHeading>
            {rendered}
        </>
    );
};
export default FilterExample;