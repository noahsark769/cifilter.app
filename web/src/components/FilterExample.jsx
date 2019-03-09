import React from 'react';
import styled from 'styled-components';
import FilterExampleImage from './FilterExampleImage';
import FilterExampleParameter from './FilterExampleParameter';
import FilterDetailSectionHeading from './FilterDetailSectionHeading';
import HorizontalImageConfiguration, { WasCropped } from './HorizontalImageConfiguration';
import { IoIosArrowRoundDown } from 'react-icons/io';

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
    console.log(props);
    return (
        <FlexParent column>
            <Container>
                <Column>
                    {props.imageParameters.map((value) => {
                        const {name, type, additionalData} = value;
                        return (<FilterExampleImage
                                    key={name}
                                    name={name}
                                    filename={`${props.basepath}/${additionalData.image}`}
                                />);
                    })}
                </Column>
                <Column>
                    {props.nonImageParameters.map((value) => {
                        return (<FilterExampleParameter
                                    key={value.name}
                                    data={value}
                                    className="margin-bottom--md"
                                />);
                    })}
                </Column>
            </Container>
            <ArrowContainer>
                <IoIosArrowRoundDown size={50} color="#999" />
            </ArrowContainer>
            <OutputImageContainer>
                <OutputImageWrapper>
                    <FilterExampleImage
                        name="outputImage"
                        filename={`${props.basepath}/${props.outputImageData.image}`}
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
    if (nonImageParameters.length == 0 && imageParameters.length == 2) {
        rendered = (<HorizontalImageConfiguration
            basepath={props.example.basepath}
            outputImageData={outputImageData.additionalData}
            parameterValues={props.example.data.parameterValues}
            />);
    } else {
        rendered = (<NormalImageConfiguration
            basepath={props.example.basepath}
            outputImageData={outputImageData.additionalData}
            nonImageParameters={nonImageParameters}
            imageParameters={imageParameters}
            />); 
    }

    return (
        <>
            <FilterDetailSectionHeading>Example</FilterDetailSectionHeading>
            {rendered}
        </>
    );
};
export default FilterExample;